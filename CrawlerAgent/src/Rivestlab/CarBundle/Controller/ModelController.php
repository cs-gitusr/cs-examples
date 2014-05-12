<?php

namespace Rivestlab\CarBundle\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;

use Rivestlab\CarBundle\Entity\Model;
use Rivestlab\CarBundle\Form\ModelType;

/**
 * Model controller.
 *
 */
class ModelController extends Controller
{
    /**
     * Lists all Model entities.
     *
     */
    public function indexAction()
    {
        $em = $this->getDoctrine()->getManager();

        $entities = $em->getRepository('RivestlabCarBundle:Model')->findAll();

        return $this->render('RivestlabCarBundle:Model:index.html.twig', array(
            'entities' => $entities,
        ));
    }

    /**
     * Creates a new Model entity.
     *
     */
    public function createAction(Request $request)
    {
        $entity  = new Model();
        $form = $this->createForm(new ModelType(), $entity);
        $form->bind($request);

        if ($form->isValid()) {
            $em = $this->getDoctrine()->getManager();
            $em->persist($entity);
            $em->flush();

            return $this->redirect($this->generateUrl('modelcrud_show', array('id' => $entity->getId())));
        }

        return $this->render('RivestlabCarBundle:Model:new.html.twig', array(
            'entity' => $entity,
            'form'   => $form->createView(),
        ));
    }

    /**
     * Displays a form to create a new Model entity.
     *
     */
    public function newAction()
    {
        $entity = new Model();
        $form   = $this->createForm(new ModelType(), $entity);

        return $this->render('RivestlabCarBundle:Model:new.html.twig', array(
            'entity' => $entity,
            'form'   => $form->createView(),
        ));
    }

    /**
     * Finds and displays a Model entity.
     *
     */
    public function showAction($id)
    {
        $em = $this->getDoctrine()->getManager();

        $entity = $em->getRepository('RivestlabCarBundle:Model')->find($id);

        if (!$entity) {
            throw $this->createNotFoundException('Unable to find Model entity.');
        }

        $deleteForm = $this->createDeleteForm($id);

        return $this->render('RivestlabCarBundle:Model:show.html.twig', array(
            'entity'      => $entity,
            'delete_form' => $deleteForm->createView(),        ));
    }

    /**
     * Displays a form to edit an existing Model entity.
     *
     */
    public function editAction($id)
    {
        $em = $this->getDoctrine()->getManager();

        $entity = $em->getRepository('RivestlabCarBundle:Model')->find($id);

        if (!$entity) {
            throw $this->createNotFoundException('Unable to find Model entity.');
        }

        $editForm = $this->createForm(new ModelType(), $entity);
        $deleteForm = $this->createDeleteForm($id);

        return $this->render('RivestlabCarBundle:Model:edit.html.twig', array(
            'entity'      => $entity,
            'edit_form'   => $editForm->createView(),
            'delete_form' => $deleteForm->createView(),
        ));
    }

    /**
     * Edits an existing Model entity.
     *
     */
    public function updateAction(Request $request, $id)
    {
        $em = $this->getDoctrine()->getManager();

        $entity = $em->getRepository('RivestlabCarBundle:Model')->find($id);

        if (!$entity) {
            throw $this->createNotFoundException('Unable to find Model entity.');
        }

        $deleteForm = $this->createDeleteForm($id);
        $editForm = $this->createForm(new ModelType(), $entity);
        $editForm->bind($request);

        if ($editForm->isValid()) {
            $em->persist($entity);
            $em->flush();

            return $this->redirect($this->generateUrl('modelcrud_edit', array('id' => $id)));
        }

        return $this->render('RivestlabCarBundle:Model:edit.html.twig', array(
            'entity'      => $entity,
            'edit_form'   => $editForm->createView(),
            'delete_form' => $deleteForm->createView(),
        ));
    }

    /**
     * Deletes a Model entity.
     *
     */
    public function deleteAction(Request $request, $id)
    {
        $form = $this->createDeleteForm($id);
        $form->bind($request);

        if ($form->isValid()) {
            $em = $this->getDoctrine()->getManager();
            $entity = $em->getRepository('RivestlabCarBundle:Model')->find($id);

            if (!$entity) {
                throw $this->createNotFoundException('Unable to find Model entity.');
            }

            $em->remove($entity);
            $em->flush();
        }

        return $this->redirect($this->generateUrl('modelcrud'));
    }

    /**
     * Creates a form to delete a Model entity by id.
     *
     * @param mixed $id The entity id
     *
     * @return Symfony\Component\Form\Form The form
     */
    private function createDeleteForm($id)
    {
        return $this->createFormBuilder(array('id' => $id))
            ->add('id', 'hidden')
            ->getForm()
        ;
    }
}
