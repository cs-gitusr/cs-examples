<?php

namespace Rivestlab\CarBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Doctrine\Common\Collections\ArrayCollection;

/**
 * Model
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class Model
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    private $id;

    /**
     * @ORM\Column(type="string", length=100)
     */
    protected $name;

    /**
     * @var ArrayCollection 
     * 
     * @ORM\OneToMany(targetEntity="Car", mappedBy="model")
     */
    protected $cars;
    
    /**
     * @var Brand Description
     * @ORM\ManyToOne(targetEntity="Brand", inversedBy="models")
     * @ORM\JoinColumn(name="brand_id", referencedColumnName="id")
     */
    protected $brand;
    
    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set name
     *
     * @param string $name
     * @return Product
     */
    public function setName($name)
    {
        $this->name = $name;
    
        return $this;
    }

    /**
     * Get name
     *
     * @return string 
     */
    public function getName()
    {
        return $this->name;
    }
    /**
     * Constructor
     */
    public function __construct()
    {
        $this->cars = new \Doctrine\Common\Collections\ArrayCollection();
    }
    


    /**
     * Add cars
     *
     * @param \Rivestlab\CarBundle\Entity\Car $cars
     * @return Model
     */
    public function addCar(\Rivestlab\CarBundle\Entity\Car $cars)
    {
        $this->cars[] = $cars;
    
        return $this;
    }

    /**
     * Remove cars
     *
     * @param \Rivestlab\CarBundle\Entity\Car $cars
     */
    public function removeCar(\Rivestlab\CarBundle\Entity\Car $cars)
    {
        $this->cars->removeElement($cars);
    }

    /**
     * Get cars
     *
     * @return \Doctrine\Common\Collections\Collection 
     */
    public function getCars()
    {
        return $this->cars;
    }

    /**
     * Set brand
     *
     * @param \Rivestlab\CarBundle\Entity\Brand $brand
     * @return Model
     */
    public function setBrand(\Rivestlab\CarBundle\Entity\Brand $brand = null)
    {
        $this->brand = $brand;
    
        return $this;
    }

    /**
     * Get brand
     *
     * @return \Rivestlab\CarBundle\Entity\Brand
     */
    public function getBrand()
    {
        return $this->brand;
    }
}